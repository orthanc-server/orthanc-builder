#include <memory>
#include <windows.h> 
#include <stdio.h>
#include <boost/thread.hpp>
#include <stdexcept>

#include "Toolbox.h"


class IService
{
public:
  virtual ~IService()
  {
  }

  virtual void Start() = 0;

  virtual void Stop() = 0;

  virtual bool HasFailed() = 0;
};



class IThreadedService
{
public:
  virtual ~IThreadedService()
  {
  }

  virtual bool Initialize() = 0;

  virtual bool Step() = 0;

  virtual void Finalize() = 0;
};


class ThreadedServiceWrapper : public IService
{
private:
  IThreadedService* service_;
  bool continue_;
  bool failure_;
  boost::thread thread_;

  static void Worker(ThreadedServiceWrapper* that)                     
  {
    if (!that->service_->Initialize())
    {
      that->failure_ = true;
      return;
    }

    while (that->continue_)
    {
      if (!that->service_->Step())
      {
        that->failure_ = true;
        break;
      }

      Sleep(1000);
    }

    that->service_->Finalize();
  }

public:
  ThreadedServiceWrapper(IThreadedService* service) :  // takes the ownership
  service_(service),
  continue_(true),
  failure_(false)
  {
  }

  virtual ~ThreadedServiceWrapper()
  {
    Stop();
    delete service_;
  }

  virtual void Start()
  {
    thread_ = boost::thread(Worker, this);
  }

  virtual void Stop()
  {
    continue_ = false;
    thread_.join();
  }

  virtual bool HasFailed()
  {
    return failure_;
  }
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


class CommandLineService : public IThreadedService
{
private:
  std::wstring workingDir_;
  std::wstring commandLine_;
  HANDLE processHandle_;
  DWORD processId_;
  bool ctrlC_;

  bool Spawn()
  {
    PROCESS_INFORMATION pi;
    STARTUPINFOW si;

    ZeroMemory(&si,sizeof(STARTUPINFOW));
    si.cb = sizeof(STARTUPINFOW);
    ZeroMemory(&pi, sizeof(pi));

    DWORD creationFlags = 0;
    if (ctrlC_)
    {
      creationFlags |= CREATE_NEW_PROCESS_GROUP;
    }

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


  bool IsAlive()
  {
    DWORD code;

    if (GetExitCodeProcess(processHandle_, &code) == 0)  // Failure
    {
      return false; 
    }

    return code == STILL_ACTIVE;
  }


  void Kill()
  {
    if (ctrlC_)
    {
      GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT, processId_);
    }
    else
    {
      TerminateProcess(processHandle_, 0);
    }
    
    // Wait until the child process exits (TerminateProcess is asynchronous)
    WaitForSingleObject(processHandle_, INFINITE);

    CloseHandle(processHandle_);
  }


public:
  CommandLineService(const std::vector<std::wstring>& arguments,
                     const std::wstring& workingDir,
                     bool ctrlC) : 
    workingDir_(workingDir),
    ctrlC_(ctrlC)
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

  virtual bool Initialize()
  {
    return Spawn();
  }

  virtual bool Step()
  {
    if (IsAlive())
    {
      return true;
    }
    else
    {
      return Spawn();
    }    
  }

  virtual void Finalize()
  {
    Kill();
  }
};



std::auto_ptr<IService> service_;
SERVICE_STATUS serviceStatus_; 
SERVICE_STATUS_HANDLE statusHandle_; 


void ControlHandler(DWORD request) 
{ 
  switch (request) 
  { 
    case SERVICE_CONTROL_STOP: 
    case SERVICE_CONTROL_SHUTDOWN: 
      if (service_.get() != NULL)
      {
        service_->Stop();
        service_.reset(NULL);
      }

      serviceStatus_.dwWin32ExitCode = 0; 
      serviceStatus_.dwCurrentState = SERVICE_STOPPED; 
      SetServiceStatus (statusHandle_, &serviceStatus_);
      return; 
 
    default:
      break;
  } 
 
  /* Report current status */
  SetServiceStatus(statusHandle_, &serviceStatus_);
 
  return; 
}


void ServiceMain(int argc, char** argv) 
{ 
  /**
   * http://msdn.microsoft.com/en-us/library/windows/desktop/ms683155(v=vs.85).aspx
   * "GenerateConsoleCtrlEvent() requires the calling code to be a
   * console application as well as the target.  This is further
   * complicated when using it in a Windows Service, as services do
   * not seem to have consoles even if the EXE is marked as a Console
   * application. Thus, I kept getting ERROR_INVALID_HANDLE when
   * trying to call GenerateConsoleCtrlEvent(). I fixed it by forcing
   * console creation in the service with AllocConsole()."
   **/
  if (!AllocConsole())
  {
    return;
  }

  serviceStatus_.dwServiceType = SERVICE_WIN32; 
  serviceStatus_.dwCurrentState = SERVICE_START_PENDING; 
  serviceStatus_.dwControlsAccepted = SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN;
  serviceStatus_.dwWin32ExitCode = 0; 
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

  /* Initialize Service */
  //service_.reset(new Tutu);
  //service_.reset(new ThreadedServiceWrapper(new Toto));

  std::wstring installDir = GetStringRegKey(L"SOFTWARE\\Orthanc\\Orthanc Server", L"InstallDir", L"");
  bool verbose = GetDWordRegKey(L"SOFTWARE\\Orthanc\\Orthanc Server", L"Verbose", 0) == 1;
  bool unlock = GetDWordRegKey(L"SOFTWARE\\Orthanc\\Orthanc Server", L"Unlock", 1) == 1; // always try to unlock the DB when starting the Service (unless disabled in the registry)

  std::vector<std::wstring> a;
  a.push_back(L"Orthanc.exe");

  if (verbose)
  {
    a.push_back(L"--verbose");
  }

  if (unlock) 
  {
    a.push_back(L"--unlock");
  }

  a.push_back(L"--logdir=Logs");
  a.push_back(L"Configuration");
  service_.reset(new ThreadedServiceWrapper(new CommandLineService(a, installDir, true)));

  if (service_.get() == NULL)
  {
    /* Initialization failed */
    serviceStatus_.dwCurrentState = SERVICE_STOPPED; 
    serviceStatus_.dwWin32ExitCode = -1; 
    SetServiceStatus(statusHandle_, &serviceStatus_); 
    return; 
  } 

  /* We report the running status to SCM. */
  serviceStatus_.dwCurrentState = SERVICE_RUNNING; 
  SetServiceStatus (statusHandle_, &serviceStatus_);
 
  /* The worker loop of a service */
  service_->Start();

  while (serviceStatus_.dwCurrentState == SERVICE_RUNNING)
  {
    if (service_->HasFailed())
    {
      serviceStatus_.dwCurrentState = SERVICE_STOPPED; 
      serviceStatus_.dwWin32ExitCode = -1; 
      SetServiceStatus(statusHandle_, &serviceStatus_);
      return;
    }

    /* TODO Improve this with a condition variable? */
    Sleep(1000);
  }
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
