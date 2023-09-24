classdef VoiceCommand
    properties
        ampThreshold = 0.2;
        timeThreshold = 1;
        deviceReader
        fileWriter
        transcriber
    end
    methods
        function obj = VoiceCommand()
            obj.deviceReader = audioDeviceReader;
            obj.fileWriter = dsp.AudioFileWriter(SampleRate=obj.deviceReader.SampleRate);
            obj.transcriber = speechClient("wav2vec2.0");
        end
        function wav = collectVoice(obj)
            while true
                lastPoll = obj.deviceReader();
                if max(abs(lastPoll)) > obj.ampThreshold
                    wav = lastPoll;
                    tic
                    while true
                        if max(abs(lastPoll)) < obj.ampThreshold
                            if toc > obj.timeThreshold
                                return
                            end
                        else
                            tic
                        end
                        lastPoll = obj.deviceReader();
                        wav = vertcat(wav, lastPoll);
                    end
                end
            end
        end
        function transcript_text = transcribe(obj, wav)
            wav = wav(1 : find(wav > obj.ampThreshold, 1, "last"));
            transcript_text = "";
            disp(length(wav))
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
            text = obj.transcribe(obj.collectVoice())
            text = strjoin(table2array(text), " ")
        end
    end
end