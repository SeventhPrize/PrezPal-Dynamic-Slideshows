classdef VoiceCommand
    %{
    Encapsulates properties and methods for getting microphone voice
    command prompts.
    %}
    properties
        ampThreshold = 0.001;   % threshold for microphone waveform to begin recording speech
        timeThreshold = 1;      % threshold for microphone inactivity before terminating waveform recording
        deviceReader            % audioDeviceReader object
        fileWriter              % dsp.AudioFileWriter object               
        transcriber             % speechClient object
    end
    methods
        function obj = VoiceCommand()
            %{
            Initializes this VoiceCommand object
            %}
            obj.deviceReader = audioDeviceReader;
            obj.fileWriter = dsp.AudioFileWriter(SampleRate=obj.deviceReader.SampleRate);
            obj.transcriber = speechClient("wav2vec2.0"); % wav2vec2.0 is the only free speechClient lol
        end
        function wav = collectVoice(obj)
            %{
            Collects the waveform of one speech session.
            RETURNS
                numerical array representing speech waveform
            %}

            % Loop until speech pattern session detected
            while true
                lastPoll = obj.deviceReader(); % Poll the audio device

                % If amplitude threshold hit, start speech session
                % recording
                if max(abs(lastPoll)) > obj.ampThreshold
                    wav = lastPoll;
                    tic
                    while true

                        % Return waveform if the inactivity threshold is
                        % reached
                        if max(abs(lastPoll)) < obj.ampThreshold
                            if toc > obj.timeThreshold
                                return
                            end
                        else
                            tic
                        end

                        % Collect waveform
                        lastPoll = obj.deviceReader();
                        wav = vertcat(wav, lastPoll);
                    end
                end
            end
        end
        function transcript_text = transcribe(obj, wav)
            %{
            Transcribes a waveform speech into English text
            RETURNS
                table column containing transcribed words
            %}

            % Filter out waveform from after speech concluded
            wav = wav(1 : find(wav > obj.ampThreshold, 1, "last"));

            % Default value for transcription text
            transcript_text = "";

            % Transcribe text
            try
                obj.fileWriter(wav);
                [y, fs] = audioread("output.wav");
                soundsc(y, fs)
                transcript = speech2text(obj.transcriber, y, fs);
                transcript_text = transcript(:, 1);
            catch
            end
            release(obj.deviceReader)
            release(obj.fileWriter)
        end
        function text = getCommand(obj)
            %{
            Gets the string of the voice command
            RETURNS
                string of the voice command
            %}

            % Collect voice waveform and transcribe
            text = obj.transcribe(obj.collectVoice());

            % Format to single string
            text = strjoin(table2array(text), " ")

            % Corrections
            if mod(count(text, '"'), 0) == 1
                text = text + '"';
            end
            if text(end) ~= "}"
                text = text + "}";
            end
        end
    end
end