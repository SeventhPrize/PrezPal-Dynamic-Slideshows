classdef VoiceCommand
    properties
        ampThreshold = 0.1;
        timeThreshold = 1;
        deviceReader = audioDeviceReader;
        fileWriter = dsp.AudioFileWriter(SampleRate=deviceReader.SampleRate);
        transcriber = speechClient("wav2vec2.0");
    end
    methods
        function obj = VoiceCommand()
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
                                break
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
            if length(wav) > 2 * length(lastPoll)
                try
                    obj.fileWriter(wav);
                    [y, fs] = audioread("output.wav");
                    soundsc(y, fs)
                    transcript = speech2text(obj.transcriber, y, fs);
                    transcript_text = transcript(:, 1);
                catch
                end
            end
            release(obj.deviceReader)
            release(obj.fileWriter)
        end
        function text = getCommand(obj)
            text = obj.transcribe(obj.collectVoice());
        end
    end
end