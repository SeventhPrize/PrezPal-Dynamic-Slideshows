%{
Generates the base PrezPalDemo.pptx presentation.
Consists of only title slide.
%}

import mlreportgen.ppt.*

% Create pptx file
filename = "demo/PrezPalDemo.pptx";
pptview(filename, "closeapp")
ppt = Presentation(filename);
open(ppt);

% Make title slide
titleSlide = add(ppt, "Title Slide");
bg = add(titleSlide, Picture("prettify/PrezPal_Title.png"));
bg.X = "0px";
bg.Y = "0px";
bg.Width = "13.3in";
bg.Height = "7.5in";
replace(titleSlide, "Title", "PrezPal" + newline() + "Dynamic Slideshows")
replace(titleSlide, "Subtitle", "George Lyu & Ivana Hsyung")
replace(titleSlide, "Footer", "Powered by PrezPal")

% Close pptx
close(ppt);
pptview(filename)