% Reset environment
clc, clear
loadenv(".env")

% Make base powerpoint
makeDemo

% Get powerpoint properties
pptxPath = "PrezPalDemo.pptx";
summary = fscanf(fopen("PrezPalSummary.txt",'r'), "%c");
imList = ["demo/frustrated_presenter.png", "demo/happy_presenter.jpg," "demo/generic_presentation.png", "demo/voice_command.png", "demo/data_science_flowchart.png", "demo/matlab_logo.png", "demo/powerpoint_logo.png"];
fewShot = readtable("demo/Few-shot learning.csv");

% Initialize objects
pp = PrezPal(pptxPath, summary, imList, fewShot);
vc = VoiceCommand();
gpt = AskGPT();

% Notify ready
disp("BEGIN")

% 
while true
    try
    prompt = vc.getCommand()
    if strlength(prompt) > 3
        msgs = pp.buildPrompt(prompt)
        json = gpt.ask(msgs)
        pp.addSlide(jsondecode(json))
    end
    catch
    end
end