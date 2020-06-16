# Class responsive calling the right rest method depending on HTTP Method, path & ENDPOINTS constant of child class
class RestServlet < WEBrick::HTTPServlet::AbstractServlet
  # Retrive data
  # Should return : 200, 401 (UNAUTHORIZED -> bad auth), 403 (FORBIDDEN -> wrong rights), 404,
  # 405 (METHOD NOT ALLOWED, no get for this endpoint)
  def do_GET(request, response)
    status, contents = resolve_path(request, :get)

    response.status = status
    response['Content-Type'] = 'application/json'
    response.body = JSON.generate(contents)
  end

  # Update data or put data if ID is known
  # Should return : 204, 401 (UNAUTHORIZED -> bad auth), 403 (FORBIDDEN -> wrong rights), 404,
  # 405 (METHOD NOT ALLOWED, no get for this endpoint)
  def do_PUT(request, response)
    status, contents = resolve_path(request, :put)

    response.status = status
    response['Content-Type'] = 'application/json'
    response.body = JSON.generate(contents)
  end

  # Delete data
  # Should return : 204, 401 (UNAUTHORIZED -> bad auth), 403 (FORBIDDEN -> wrong rights), 404,
  # 405 (METHOD NOT ALLOWED, no get for this endpoint)
  def do_DELETE(request, response)
    status, contents = resolve_path(request, :delete)

    response.status = status
    response['Content-Type'] = 'application/json'
    response.body = JSON.generate(contents)
  end

  # Create data
  # Should return : 200, 401 (UNAUTHORIZED -> bad auth), 403 (FORBIDDEN -> wrong rights), 404,
  # 405 (METHOD NOT ALLOWED, no get for this endpoint), 409 (CONFLICT duplicate)
  def do_POST(request, response)
    status, contents = resolve_path(request, :post)

    response.status = status
    response['Content-Type'] = 'application/json'
    response.body = JSON.generate(contents)
  end

  def resolve_path(request, method)
    self.class::ENDPOINTS.each do |endpoint, methods|
      if (matches = request.path.match(endpoint))
        if (method_name = methods[method])
          return send(method_name, request, *matches.captures)
        else
          return 405, { error: "#{methods[:id]} has no #{method} method." }
        end
      end
    end
    return 404, { error: "Couldn't find endpoint for #{request.path}"}
  end
end
