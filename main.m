%{
Main script for demonstrating PrezPal product
%}

% Reset environment
clc, clear
loadenv(".env")

% Make base powerpoint
makeDemo

% Get powerpoint properties
pptxPath = "demo/PrezPalDemo.pptx"; % path to the demo presentation
summary = fscanf(fopen("demo/PrezPalSummary.txt",'r'), "%c"); % presentation summary text
imList = ["demo/frustrated_presenter.png", "demo/happy_presenter.jpg," "demo/generic_presentation.png", "demo/voice_command.png", "demo/data_science_flowchart.png", "demo/matlab_logo.png", "demo/powerpoint_logo.png"]; % list of images that can be included
fewShot = readtable("demo/Few-shot learning.csv"); % table with few-shot learning data

% Initialize objects
pp = PrezPal(pptxPath, summary, imList, fewShot);
vc = VoiceCommand();
gpt = AskGPT();

% Notify ready
disp("BEGIN")

% Repeatedly get voice commands and add slides accordingly
while true
    try
        prompt = vc.getCommand() % get voice command
        if strlength(prompt) > 3
            msgs = pp.buildPrompt(prompt); % build few-shot learning
            json = gpt.ask(msgs) % get json of new slide to add
            pp.addSlide(jsondecode(json)) % add slide 
        end
    catch
    end
end