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
            obj.max_tokens = 50;
        end
        function responseContent = ask(obj, messages)
            parameters = struct("model", obj.model_type, ...
                                "max_tokens", obj.max_tokens, ...
                                "messages", messages);

            request = matlab.net.http.RequestMessage('post', headers, parameters);

            response = send(request, URI(obj.api_endpoint));
          
            responseContent = response.Body.Data.choices.message.content;
        end
    end
end