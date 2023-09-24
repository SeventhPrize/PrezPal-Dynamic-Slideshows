classdef AskGPT
    properties
        api_endpoint
        model_type
        max_tokens
    end
    methods
        function obj = AskGPT()
            obj.api_endpoint = "https://api.openai.com/v1/chat/completions";
            obj.model_type = "gpt-3.5-turbo";
            obj.max_tokens = 80;
        end
        function responseContent = ask(obj, messages)
            import matlab.net.*
            import matlab.net.http.*

            parameters = struct("model", obj.model_type, ...
                "max_tokens", obj.max_tokens, ...
                "messages", messages);

            headers = matlab.net.http.HeaderField('Content-Type', 'application/json');
            headers(2) = matlab.net.http.HeaderField('Authorization', ["Bearer " + getenv("OPEN_AI_API")]);

            request = matlab.net.http.RequestMessage('post', headers, parameters);

            response = send(request, URI(obj.api_endpoint));

            responseContent = response.Body.Data.choices.message.content;
        end
    end
end