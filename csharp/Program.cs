using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);
var port = Environment.GetEnvironmentVariable("PORT") ?? "8020";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");
builder.Services.ConfigureHttpJsonOptions(options => {
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});

var app = builder.Build();

app.MapGet("/", (HttpContext context) =>
{
    var traceId = context.Request.Headers["X-Trace-Id"].ToString();
    if (string.IsNullOrEmpty(traceId)) traceId = Guid.NewGuid().ToString("N");
    var timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
    
    var responseObj = new
    {
        timestamp = timestamp,
        level = "info",
        service = "csharp-api",
        message = "GET / success",
        request = new
        {
            method = context.Request.Method,
            url = context.Request.Path.Value,
            headers = new { user_agent = context.Request.Headers.UserAgent.ToString() },
            ip = context.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1"
        },
        response = new
        {
            status_code = 200,
            response_time_ms = 1
        },
        meta = new
        {
            request_id = traceId,
            user_id = 42
        }
    };

    var accessLog = JsonSerializer.Serialize(new
    {
        code = 200,
        message = "OK",
        method = context.Request.Method,
        path = context.Request.Path.Value,
        trace_id = traceId,
        timestamp = timestamp
    });
    
    Console.WriteLine(accessLog);
    return Results.Json(responseObj);
});

app.MapFallback((HttpContext context) => 
{
    var traceId = context.Request.Headers["X-Trace-Id"].ToString();
    if (string.IsNullOrEmpty(traceId)) traceId = Guid.NewGuid().ToString("N");
    var timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");

    var accessLog = JsonSerializer.Serialize(new
    {
        code = 404,
        message = "Not Found",
        method = context.Request.Method,
        path = context.Request.Path.Value,
        trace_id = traceId,
        timestamp = timestamp
    });
    
    Console.WriteLine(accessLog);
    context.Response.StatusCode = 404;
    return Results.Empty;
});

Console.WriteLine($"Starting C# server at http://127.0.0.1:{port}");
app.Run();
