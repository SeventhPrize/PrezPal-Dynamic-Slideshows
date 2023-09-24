import matlab.net.*
import matlab.net.http.*

loadenv(".env")

% Define the API endpoint Davinci
api_endpoint = "https://api.openai.com/v1/chat/completions";

% Define the API key from https://beta.openai.com/account/api-keys
api_key = getenv("OPEN_AI_API");

% Define the parameters for the API request
prompt = "How many tablespoons are in 2 cups?"
parameters = struct("model", "gpt-3.5-turbo", ...
                    "max_tokens", 50, ...
                    "messages", [struct("role", "system", ...
                                        "content", "Make PowerPoint presentations."), ...
                                 struct("role", "user", ...
                                        "content", prompt)]);

% Define the headers for the API request
headers = matlab.net.http.HeaderField('Content-Type', 'application/json');
headers(2) = matlab.net.http.HeaderField('Authorization', ["Bearer " + api_key]);

% Define the request message
request = matlab.net.http.RequestMessage('post', headers, parameters);

% Send the request and store the response
response = send(request, URI(api_endpoint));

% Extract the response text
disp(response.Body.Data)
disp(response.Body.Data.usage)
disp(response.Body.Data.choices.message)
