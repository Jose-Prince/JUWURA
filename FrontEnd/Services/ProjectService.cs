using System.Net.Http.Json;

public class ProjectService
{
    private readonly HttpClient _httpClient;

    public ProjectService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<User?> getUser(string email, string password) 
    {
        try
        {
            var url = $"api/login/{email}/{password}";
            return await _httpClient.GetFromJsonAsync<User>(url);
            
        }
        catch (HttpRequestException ex)
        {
            Console.WriteLine($"Request error: {ex.Message}");
            return null;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Unexpected error: {ex.Message}");
            return null;
        }
    }
}