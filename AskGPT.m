classdef AskGPT
    %{
    Encapsulates methods for prompting GPT 3.5-Turbo for slide creation
    information.
    %}
    properties
        api_endpoint    % URI endpoint for Open AI endpoint
        model_type      % The model type from Open AI
        max_tokens      % The maximum number of tokens to generate for each slide
    end
    methods
        function obj = AskGPT()
            %{
            Initializes this AskGPT object
            %}
            obj.api_endpoint = "https://api.openai.com/v1/chat/completions";
            obj.model_type = "gpt-3.5-turbo";
            obj.max_tokens = 100;
        end
        function responseContent = ask(obj, messages)
            %{
            Prompts GPT model to complete the next message in the given
            message log
            INPUT
                messages; list of structs with role, content fields as
                given to GPT API
            RETURNS
                the string content of the completed message from GPT model
            %}
            import matlab.net.*
            import matlab.net.http.*

            % Assemble request parameters
            parameters = struct("model", obj.model_type, ...
                "max_tokens", obj.max_tokens, ...
                "messages", messages);

            % Assemble request headers
            headers = matlab.net.http.HeaderField('Content-Type', 'application/json');
            headers(2) = matlab.net.http.HeaderField('Authorization', "Bearer " + getenv("OPEN_AI_API"));

            % Make request
            request = matlab.net.http.RequestMessage('post', headers, parameters);

            % Receive response
            response = send(request, URI(obj.api_endpoint));
            responseContent = response.Body.Data.choices.message.content;
            responseContent = string(extractBetween(responseContent, ...
                strfind(responseContent, "{"), ...
                strlength(responseContent)));
        end
    end
end