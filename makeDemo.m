import mlreportgen.ppt.*
filename = "PrezPalDemo.pptx";
ppt = Presentation(filename);
open(ppt);
titleSlide = add(ppt, "Title Slide");
replace(titleSlide, "Title", "PrezPal" + newline() + "Dynamic Slideshows")
replace(titleSlide, "Subtitle", "George Lyu")
replace(titleSlide, "Footer", "Powered by PrezPal")
close(ppt);
pptview(filename)