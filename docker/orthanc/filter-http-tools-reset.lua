function IncomingHttpRequestFilter(method, uri, ip, username, httpHeaders)

  if method == 'POST' and uri == '/tools/reset' then
    -- regenerate the /tmp/orthanc.json before reseting orthanc
    os.execute("cd /startup && python3 generateConfiguration.py")    
  end

  return true
end