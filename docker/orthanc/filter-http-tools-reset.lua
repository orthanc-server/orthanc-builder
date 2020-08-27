function IncomingHttpRequestFilter(method, uri, ip, username, httpHeaders)
  -- Only allow GET requests for non-admin users

  if method == 'POST' and uri == '/tools/reset' then
    os.execute("cd /startup && python3 generateConfiguration.py")    
  end

  return true
end