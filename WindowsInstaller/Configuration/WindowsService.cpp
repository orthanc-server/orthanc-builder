/**
 * Orthanc - A Lightweight, RESTful DICOM Store
 * Copyright (C) 2012-2016 Sebastien Jodogne, Medical Physics
 * Department, University Hospital of Liege, Belgium
 * Copyright (C) 2017-2024 Osimis S.A., Belgium
 * Copyright (C) 2021-2024 Sebastien Jodogne, ICTEAM UCLouvain, Belgium
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 **/



/**

   Useful command-line tools to debug Windows services:
   
   $ eventvwr
   
   $ services.msc
   
   $ sc queryex orthanc
   
   $ sc qfailure orthanc

 **/




#include <memory>
#include <windows.h> 
#include <stdio.h>
#include <boost/thread.hpp>
#include <stdexcept>

#include "Toolbox.h"



enum ServiceStatus
{
  ServiceStatus_Running,
  ServiceStatus_Crash,
  ServiceStatus_Stopped
};


class IService
{
public:
  virtual ~IService()
  {
  }

  virtual bool Initialize() = 0;

  virtual ServiceStatus GetStatus() = 0;

  // Start the shutdown of the service, check "IsRunning()" to monitor when
  // the service is actually stopped
  virtual void Kill(bool isWindowsShutdown) = 0;
};


static void QuoteArgument(std::wstring& commandLine,
                          const std::wstring& argument,
                          bool force)
    
/*
  http://blogs.msdn.com/b/twistylittlepassagesallalike/archive/2011/04/23/everyone-quotes-arguments-the-wrong-way.aspx
    
  Routine Description:
    
  This routine appends the given argument to a command line such
  that CommandLineToArgvW will return the argument string unchanged.
  Arguments in a command line should be separated by spaces; this
  function does not add these spaces.
    
  Arguments:
    
  commandLine - Supplies the command line to which we append the encoded argument string.

  argument - Supplies the argument to encode.

  force - Supplies an indication of whether we should quote
  the argument even if it does not contain any characters that would
  ordinarily require quoting.
    
  Return Value:
    
  None.
    
  Environment:
    
  Arbitrary.
    
  --*/
    
{
  // Unless we're told otherwise, don't quote unless we actually need
  // to do so --- hopefully avoid problems if programs won't parse
  // quotes properly.
    
  if (force == false &&
      argument.empty() == false &&
      argument.find_first_of(L" \t\n\v\"") == argument.npos)
  {
    commandLine.append(argument);
  }
  else 
  {
    commandLine.push_back(L'"');
        
    for (std::wstring::const_iterator it = argument.begin(); ; ++it) 
    {
      unsigned numberBackslashes = 0;
        
      while (it != argument.end() && *it == L'\\') 
      {
        ++it;
        ++numberBackslashes;
      }
        
      if (it == argument.end()) 
      {
        // Escape all backslashes, but let the terminating
        // double quotation mark we add below be interpreted
        // as a metacharacter.
        commandLine.append(numberBackslashes * 2, L'\\');
        break;
      }
      else if (*it == L'"') 
      {
        // Escape all backslashes and the following
        // double quotation mark.
        commandLine.append(numberBackslashes * 2 + 1, L'\\');
        commandLine.push_back(*it);
      }
      else 
      {
        // Backslashes aren't special here.
        commandLine.append(numberBackslashes, L'\\');
        commandLine.push_back(*it);
      }
    }
    
    commandLine.push_back(L'"');
  }
}


class CommandLineService : public IService
{
private:
  std::wstring workingDir_;
  std::wstring commandLine_;
  HANDLE processHandle_;
  DWORD processId_;
  int restartCounter_;
  int maxRestartCount_;

  bool Spawn()
  {
    if (processHandle_ != NULL)
    {
      return false;  // Cannot start twice the service
    }
    
    PROCESS_INFORMATION pi;
    STARTUPINFOW si;

    ZeroMemory(&si,sizeof(STARTUPINFOW));
    si.cb = sizeof(STARTUPINFOW);
    ZeroMemory(&pi, sizeof(pi));

    DWORD creationFlags = 0;

    /**
     * **NEVER USE** the following flag (that was in use in installers
     * <= 21.1.2):
     * 
     * creationFlags |= CREATE_NEW_PROCESS_GROUP;
     *
     * If this flag is present, Windows shutdown doesn't work. Indeed,
     * the "Orthanc.exe" is created in another process group than
     * "OrthancService.exe": As "Orthanc.exe" does not handle
     * "SERVICE_CONTROL_SHUTDOWN", it does receives CTRL-BREAK, but it
     * has not the time to finalize its termination as it cannot
     * report the "SERVICE_STOP_PENDING" per se. This leads to issue
     * 48 "Windows service not stopped properly on system shutdown or
     * restart" (https://orthanc.uclouvain.be/bugs/show_bug.cgi?id=48).
     *
     * Unfortunately, if "Orthanc.exe" is in the same process group
     * than "OrthancService.exe", Windows shutdown works, but the
     * command
     * "GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT,processId_);" (which
     * was in use in installers <= 21.1.2) cannot be used to manually
     * stop the service: "Orthanc.exe" never receives the "CTRL-BREAK"
     * signal. I am unsure why, but explanations might be found at:
     * https://docs.microsoft.com/en-us/windows/console/generateconsolectrlevent
     *
     * To stop "Orthanc.exe", we send "CTRL-C" to the entire process
     * group (that includes both "OrthancService.exe" and
     * "Orthanc.exe"), but we protect "OrthancService.exe" from being
     * killed by CTRL-C by temporarily disabling the CTRL-C handler
     * using "SetConsoleCtrlHandler()".
     * 
     * Altogether, the trick is thus to disambiguate between "Windows
     * shutdowns" (no need to kill "Orthanc.exe") and "manual service
     * stop" (need to send CTRL-C to "Orthanc.exe"). This is
     * implemented in the "Kill()" function.
     *
     * Link to the earlier, incorrect implementation:
     * https://bitbucket.org/osimis/orthanc-builder/src/cc47276ba9ba02835e957f500c40978cd57628eb/WindowsInstaller/Configuration/WindowsService.cpp
     **/

    if (!CreateProcessW(NULL,   // No module name (use command line)
                        const_cast<wchar_t*>(commandLine_.c_str()),
                        NULL,   // Process handle not inheritable
                        NULL,   // Thread handle not inheritable
                        TRUE,   // Handle inheritance
                        creationFlags,
                        NULL,   // Use parent's environment block
                        workingDir_.c_str(),
                        &si,    // Pointer to STARTUPINFOW structure
                        &pi))   // Pointer to PROCESS_INFORMATION structure
    {
      return false;
    }

    CloseHandle(pi.hThread);  // Unnecessary handle
    processHandle_ = pi.hProcess;
    processId_ = pi.dwProcessId;

    return true;
  }


  ServiceStatus GetStatusInternal()
  {
    DWORD code;

    if (processHandle_ == NULL)
    {
      return ServiceStatus_Stopped;
    }
    else if (GetExitCodeProcess(processHandle_, &code) == 0)  // Failure
    {
      return ServiceStatus_Crash;
    }
    else if (code == STILL_ACTIVE)
    {
      return ServiceStatus_Running;
    }
    else if (code != 0)
    {
      return ServiceStatus_Crash;
    }
    else
    {
      return ServiceStatus_Stopped;
    }
  }


public:
  CommandLineService(const std::vector<std::wstring>& arguments,
                     const std::wstring& workingDir,
                     int maxRestartCount) : 
    workingDir_(workingDir),
    processHandle_(NULL),
    restartCounter_(0),
    maxRestartCount_(maxRestartCount)
  {
    if (arguments.size() == 0)
    {
      throw std::runtime_error("No argument");
    }

    for (size_t i = 0; i < arguments.size(); i++)
    {
      if (i > 0)
      {
        commandLine_.push_back(L' ');
      }

      QuoteArgument(commandLine_, arguments[i], true);
    }
  }

  virtual ~CommandLineService()
  {
    if (processHandle_ != NULL)
    {
      CloseHandle(processHandle_);
    }
  }

  virtual bool Initialize()
  {
    return Spawn();
  }

  virtual ServiceStatus GetStatus()
  {
    switch (GetStatusInternal())
    {
      case ServiceStatus_Running:
        return ServiceStatus_Running;

      case ServiceStatus_Crash:

#if 0
        // The "maxRestartCount_" is disabled since Orthanc 1.9.1
        if (maxRestartCount_ == 0 ||
            restartCounter_ < maxRestartCount_)
        {
          restartCounter_++;
          Sleep(restartCounter_ * 1000); // wait more and more before it restarts
          if (Spawn())
          {
            return ServiceStatus_Running;
          }
        }
#endif

        return ServiceStatus_Crash;

      case ServiceStatus_Stopped:
        return ServiceStatus_Stopped;

      default:
        return ServiceStatus_Crash;  // Should never occur
    }
  }

  virtual void Kill(bool isWindowsShutdown)
  {
    if (processHandle_ != NULL)
    {
      /**
       * We don't kill "Orthanc.exe" from "OrthancService.exe" in the
       * case of Windows shutdown. Indeed, in this case, Windows sends
       * CTRL-C by itself. If we send CTRL-C again, the second CTRL-C
       * will immediately cancel the stopping process of
       * "Orthanc.exe", preventing Orthanc to reach the "Orthanc has
       * stopped" log message.
       **/
      if (!isWindowsShutdown &&
          AttachConsole(processId_))
      {
        // Prevent the main process "OrthancService.exe" from being
        // killed together with "Orthanc.exe" by disabling the
        // handling of CTRL-C
        SetConsoleCtrlHandler(NULL, true);

        // From "WinSW": "Don't call GenerateConsoleCtrlEvent
        // immediately after SetConsoleCtrlHandler. A delay was
        // observed as of Windows 10, version 2004 and Windows Server
        // 2019." -> NOT VALIDATED, unsure whether this is needed
        Sleep(100);
        
        // Send CTRL-C to the entire process group (which includes
        // both "Orthanc.exe" and "OrthancService.exe")
        GenerateConsoleCtrlEvent(CTRL_C_EVENT, 0);
        
        // Restore the callback
        SetConsoleCtrlHandler(NULL, false);

        FreeConsole();
      }

      /**
       * For an abrupt termination of "Orthanc.exe" (NOT RECOMMENDED),
       * use the following line instead (this was the purpose of the
       * "ctrlC_" in installers <= 21.1.2):
       *
       * TerminateProcess(processHandle_, 0);
       **/
    }    
  }
};


#if __cplusplus < 201103L  // C++11
std::auto_ptr<IService> service_;
#else
std::unique_ptr<IService> service_;
#endif

SERVICE_STATUS serviceStatus_; 
SERVICE_STATUS_HANDLE statusHandle_;
HANDLE shutdownEvent_;
bool isWindowsShutdown_ = false;


void ReportStopped()
{
  serviceStatus_.dwCurrentState = SERVICE_STOPPED;
  SetServiceStatus(statusHandle_, &serviceStatus_);
}


void ReportStopPendingProgress()
{
  serviceStatus_.dwCurrentState = SERVICE_STOP_PENDING;
  serviceStatus_.dwCheckPoint += 1;
  serviceStatus_.dwWaitHint = 10000;
  SetServiceStatus(statusHandle_, &serviceStatus_);
}


void ReportCrash()
{
  /**
   * VERY IMPORTANT: If reporting "SERVICE_STOPPED", Windows reports
   * an error in the event log (""), but will NOT restart the service!
   * On must set "SERVICE_RUNNING" with a non-zero "dwWin32ExitCode".
   **/
  
#if 0
  serviceStatus_.dwCurrentState = SERVICE_STOPPED;
  serviceStatus_.dwWin32ExitCode = ERROR_SERVICE_SPECIFIC_ERROR;
  serviceStatus_.dwServiceSpecificExitCode = -1;
#else
  serviceStatus_.dwCurrentState = SERVICE_RUNNING;
  serviceStatus_.dwWin32ExitCode = ERROR_INTERNAL_ERROR;
#endif

  SetServiceStatus(statusHandle_, &serviceStatus_);
}


void ControlHandler(DWORD request) 
{ 
  if (request == SERVICE_CONTROL_STOP ||
      request == SERVICE_CONTROL_SHUTDOWN)
  {
    isWindowsShutdown_ = (request == SERVICE_CONTROL_SHUTDOWN);
    ReportStopPendingProgress();
    SetEvent(shutdownEvent_);
  }
  else
  { 
    /* Everything is fine, continue reporting the same status */
    SetServiceStatus(statusHandle_, &serviceStatus_);
  }
}


void ServiceMain(int argc, char** argv) 
{ 
  serviceStatus_.dwServiceType = SERVICE_WIN32_OWN_PROCESS; 
  serviceStatus_.dwCurrentState = SERVICE_START_PENDING; 
  serviceStatus_.dwControlsAccepted = 0;
  serviceStatus_.dwWin32ExitCode = NO_ERROR; 
  serviceStatus_.dwServiceSpecificExitCode = 0; 
  serviceStatus_.dwCheckPoint = 0;
  serviceStatus_.dwWaitHint = 0; 
 
  statusHandle_ = RegisterServiceCtrlHandler(SERVICE_NAME, 
                                             (LPHANDLER_FUNCTION)ControlHandler); 
  if (statusHandle_ == (SERVICE_STATUS_HANDLE)0) 
  { 
    /* Registering Control Handler failed */
    return; 
  }

  shutdownEvent_ = CreateEventW(NULL, TRUE, FALSE, NULL);
  if (shutdownEvent_ == NULL)
  {
    /* Initialization failed */
    ReportCrash();
    return;
  }

  /* Initialize Service */
  std::wstring installDir = GetStringRegKey(L"SOFTWARE\\Orthanc\\Orthanc Server", L"InstallDir", L"");
  bool verbose = GetDWordRegKey(L"SOFTWARE\\Orthanc\\Orthanc Server", L"Verbose", 0) == 1;
  int maxRestartCount = GetDWordRegKey(L"SOFTWARE\\Orthanc\\Orthanc Server", L"MaxRestartCount", 5);  // Not used anymore

  std::vector<std::wstring> a;
  a.push_back(L"Orthanc.exe");

  if (verbose)
  {
    a.push_back(L"--verbose");
  }

  a.push_back(L"--logdir=Logs");
  a.push_back(L"Configuration");
  service_.reset(new CommandLineService(a, installDir, maxRestartCount));

  /* Start the service */
  if (service_.get() == NULL ||
      !service_->Initialize())
  {
    /* Initialization failed */
    CloseHandle(shutdownEvent_);
    ReportCrash();
    return; 
  } 

  /* We report the running status to SCM. */
  serviceStatus_.dwCurrentState = SERVICE_RUNNING; 
  serviceStatus_.dwControlsAccepted = SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN;
  SetServiceStatus (statusHandle_, &serviceStatus_);
 
  while (serviceStatus_.dwCurrentState == SERVICE_RUNNING)
  {
    // Has the underlying service crashed?
    ServiceStatus s = service_->GetStatus();

    if (s != ServiceStatus_Running)
    {
      CloseHandle(shutdownEvent_);

      if (s == ServiceStatus_Crash)
      {
        ReportCrash();
      }
      else
      {
        ReportStopped();
      }
      return;
    }

    /* Wait 1 second, or immediately awake if "ControlHandler()" receives a stop/shutdown event */
    WaitForSingleObject(shutdownEvent_, 1000);
  }
  
  CloseHandle(shutdownEvent_);
  
  /* ControlHandler() has changed the status, stop the service */
  service_->Kill(isWindowsShutdown_);

  while (service_->GetStatus() == ServiceStatus_Running)
  {
    /**
     * The service is still in the shutdown phase, keep Windows
     * informed. We increment the check point counter to convince
     * Windows we're still making progress.
     **/
    ReportStopPendingProgress();
    Sleep(1000);
  }

  /* The service has stopped */
  ReportStopped();
}



int main(int argc, char *argv[]) 
{ 
  SERVICE_TABLE_ENTRY ServiceTable[2];
  ServiceTable[0].lpServiceName = SERVICE_NAME;
  ServiceTable[0].lpServiceProc = (LPSERVICE_MAIN_FUNCTION)ServiceMain;

  ServiceTable[1].lpServiceName = NULL;
  ServiceTable[1].lpServiceProc = NULL;
  // Start the control dispatcher thread for our service
  StartServiceCtrlDispatcher(ServiceTable);  

  return 0;
}
