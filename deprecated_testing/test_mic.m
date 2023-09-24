AMP_THRESHOLD = 0.1;
TIME_THRESHOLD = 1;

deviceReader = audioDeviceReader;
fileWriter = dsp.AudioFileWriter(SampleRate=deviceReader.SampleRate);
transcriber = speechClient("wav2vec2.0");

disp("Begin Signal Input...")


while true
    lastPoll = deviceReader();
    if max(abs(lastPoll)) > AMP_THRESHOLD    
        wav = lastPoll;
        tic
        while true
            if max(abs(lastPoll)) < AMP_THRESHOLD
                if toc > TIME_THRESHOLD
                    break
                end
            else
                tic
            end
            lastPoll = deviceReader();
            wav = vertcat(wav, lastPoll);
        end
        wav = wav(1 : find(wav > AMP_THRESHOLD, 1, "last"));
        if length(wav) > 2 * length(lastPoll)
            try
                fileWriter(wav);
                [y, fs] = audioread("output.wav");
                soundsc(y, fs)
                transcript = speech2text(transcriber, y, fs)
            catch
            end
        end
        release(deviceReader)
        release(fileWriter)
    end
end

