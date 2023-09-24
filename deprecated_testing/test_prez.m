import mlreportgen.ppt.*

pptview("myPresentation.pptx",'closedoc')

ppt = Presentation('myPresentation.pptx', 'myPresentation.pptx');
open(ppt)

titleSlide = add(ppt,'Title Slide');
replace(titleSlide,'Title','Create Histogram Plots');
close(ppt)
pptview("myPresentation.pptx")

pause(2)

pptview("myPresentation.pptx",'closedoc')
ppt = Presentation('myPresentation.pptx', 'myPresentation.pptx');
open(ppt)
slide2 = add(ppt,'Title and Content');
replace(slide2,'Title','Population Modeling Approach');
disp("here")
close(ppt);
pptview("myPresentation.pptx")
