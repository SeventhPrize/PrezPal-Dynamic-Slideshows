classdef PrezPal
    properties
        pptxPath
        ppSummary
        ppImageList
        generatingSlidesPptx = "GeneratingSlideDummy.pptx";
    end
    methods
        function obj = PrezPal(pptxPath, ppSummary, ppImageList)
            obj.pptxPath = pptxPath;
            obj.ppSummary = ppSummary;
            obj.ppImageList = ppImageList;
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
                "content", obj.buildSystemPrompt()),
                struct("role", "user", ...
                "content", prompt)];
        end
        function addSlide(obj, slideJson)
            import mlreportgen.ppt.*
            pptview(obj.pptxPath,'closedoc')
            ppt = Presentation(obj.pptxPath, obj.pptxPath);
            open(ppt);
            if (slideJson.Content1 == "None") && (slideJson.Content2 == "None")
                slide = add(ppt, 'Section Header');
                replace(slide, "Text", " ")
            elseif (slideJson.Content2 == "None")
                slide = add(ppt, "Title and Content");
                if ismember(slideJson.Content1, obj.ppImageList)
                    replace(slide, "Content", Picture(slideJson.Content1))
                else
                    replace(slide, "Content", slideJson.Content1)
                end
            else
                slide = add(ppt, "Two Content");
                if ismember(slideJson.Content1, obj.ppImageList)
                    replace(slide, "Left Content", Picture(slideJson.Content1))
                else
                    replace(slide, "Left Content", slideJson.Content1)
                end
                if ismember(slideJson.Content2, obj.ppImageList)
                    replace(slide, "Right Content", Picture(slideJson.Content2))
                else
                    replace(slide, "Right Content", slideJson.Content2)
                end
            end
            replace(slide, "Title", slideJson.Title)
            close(ppt);
            pptview(obj.pptxPath)
        end
    end
end