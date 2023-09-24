classdef PrezPal
    properties
        pptxPath
        ppSummary
        ppImageList
        ppFewShot
        generatingSlidesPptx = "GeneratingSlideDummy.pptx";
    end
    methods
        function obj = PrezPal(pptxPath, ppSummary, ppImageList, ppFewShot)
            obj.pptxPath = pptxPath;
            obj.ppSummary = ppSummary;
            obj.ppImageList = ppImageList;
            obj.ppFewShot = ppFewShot;
            pptview(obj.generatingSlidesPptx)
            pptview(obj.pptxPath)
        end
        function str = buildSystemPrompt(obj)
            introStr = "Write informative, professional, concise content to be included in PowerPoint slides. The presentation has the following summary:";
            imageIntroStr = "The following images are available:";
            str = strcat(introStr, " ", ...
                obj.ppSummary, " ", ...
                imageIntroStr, " ", ...
                strjoin(obj.ppImageList, "; "));
        end
        function msg = buildPrompt(obj, prompt)
            msg = [struct("role", "system", ...
                "content", obj.buildSystemPrompt())];
            for row = 1 : height(obj.ppFewShot)
                example = [struct("role", "user", ...
                    "content", obj.ppFewShot.Prompt(row)),
                    struct("role", "assistant", ...
                    "content", strcat("{", '"Title":', ...
                    string(obj.ppFewShot.Title(row)), ...
                    ', "Content1":', ...
                    string(obj.ppFewShot.Content1(row)), ...
                    ', "Content2":', ...
                    string(obj.ppFewShot.Content2(row)), ...
                    "}"))];
                msg = vertcat(msg, example);
            end
            msg = vertcat(msg, [struct("role", "user", ...
                "content", prompt)]);
        end
        function addSlide(obj, slideJson)
            import mlreportgen.ppt.*
            pptview(obj.pptxPath,'closedoc')
            ppt = Presentation(obj.pptxPath, obj.pptxPath);
            open(ppt);
            if (slideJson.Content1 == "None") && (slideJson.Content2 == "None")
                slide = add(ppt, 'Section Header');
                add(slide, Picture("prettify/PrezPal_SectionHeader.jpg"))
                replace(slide, "Text", " ")
            elseif (slideJson.Content2 == "None")
                slide = add(ppt, "Title and Content");
                add(slide, Picture("prettify/PrezPal_Reg_Var1.jpg"))
                try
                    replace(slide, "Content", Picture(slideJson.Content1))
                catch
                    replace(slide, "Content", slideJson.Content1)
                end
            else
                slide = add(ppt, "Two Content");
                add(slide, Picture("prettify/PrezPal_Comparison.jpg"))
                try
                    replace(slide, "Left Content", Picture(slideJson.Content1))
                catch
                    replace(slide, "Left Content", slideJson.Content1)
                end
                try
                    replace(slide, "Right Content", Picture(slideJson.Content2))
                catch
                    replace(slide, "Right Content", slideJson.Content2)
                end
            end
            replace(slide, "Title", slideJson.Title)
            close(ppt);
            pptview(obj.pptxPath)
        end
    end
end