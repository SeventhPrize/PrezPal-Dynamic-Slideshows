classdef PrezPal
    %{
    Encapsulates properties for new PowerPoint slides from input voice
    commands using GPT generative AI
    %}
    properties
        pptxPath        % path to the demo powerpoint
        ppSummary       % summary of the powerpoint presentation
        ppImageList     % list of strings of paths to the images related to the presentation
        ppFewShot       % table of one-shot data
        generatingSlidesPptx = "demo/GeneratingSlideDummy.pptx"; % path to the dummy background powerpoint
    end
    methods
        function obj = PrezPal(pptxPath, ppSummary, ppImageList, ppFewShot)
            %{
            Initializes this PrezPal object
            INPUT
                pptxPath; path to the demo powerpoint
                ppSummary; summary of the powerpoint presentation
                ppImageList; list of strings of paths to the images related to the presentation
                ppFewShot; table of one-shot data
            %}
            obj.pptxPath = pptxPath;
            obj.ppSummary = ppSummary;
            obj.ppImageList = ppImageList;
            obj.ppFewShot = ppFewShot;

            % Open the dummy and demo powerpoints
            pptview(obj.generatingSlidesPptx)
            pptview(obj.pptxPath)
        end
        function str = buildSystemPrompt(obj)
            %{
            RETURNS the content for the system message. Includes summary
            and image list information.
            %}
            introStr = "Write informative, professional, concise content to be included in PowerPoint slides. The presentation has the following summary:";
            imageIntroStr = "The following images are available:";
            str = strcat(introStr, " ", ...
                obj.ppSummary, " ", ...
                imageIntroStr, " ", ...
                strjoin(obj.ppImageList, "; "), " ", ...
                "Return message as JSON struct containing fields Title, Content1, Content2.");
        end
        function msg = buildPrompt(obj, prompt)
            %{
            RETURNS the entire prompt for the GPT model, including few-shot
            learning data
            %}

            % System message
            msg = [struct("role", "system", ...
                "content", obj.buildSystemPrompt())];

            % Few-shot learning messages
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

            % Final prompt message
            msg = vertcat(msg, [struct("role", "user", ...
                "content", prompt)]);
        end
        function addSlide(obj, slideJson)
            %{
            Adds a slide to the end of the pptxPath powerpoint with fields
            described by the given Json
            INPUT
                slideJson; json struct describing which fields to include
                in the new slide
                    Title is always included in the new slide
                    If any Content 1 and 2 are None, then the slide
                    emphasizes the Title in a Title and Header slide
                    If Content 2 is None, then the slide emphasizes the
                    data in Content 1 in a Title and Content slide.
                    If all fields are valid, then the slide produces two
                    text columns in a Two Content slide
            %}
            import mlreportgen.ppt.*
            
            % Close the powerpoint window and open the object
            pptview(obj.pptxPath,'closedoc')
            ppt = Presentation(obj.pptxPath, obj.pptxPath);
            open(ppt);

            % If Contents are missing, add them as None
            if ~isfield(slideJson, "Content2")
                slideJson.Content2 = "None";
            end
            if ~isfield(slideJson, "Content1")
                slideJson.Content1 = "None";
            end

            % Create Section Header slide if not Content is given
            if (slideJson.Content1 == "None") && (slideJson.Content2 == "None")
                slide = add(ppt, 'Section Header');
                bg = add(slide, Picture("prettify/PrezPal_SectionHeader.png"));
                bg.X = "0px";
                bg.Y = "0px";
                bg.Width = "13.3in";
                bg.Height = "7.5in";
                replace(slide, "Text", " ")

            % Create Title and Content slide if Content1 is given
            elseif (slideJson.Content2 == "None")
                slide = add(ppt, "Title and Content");
                bg = add(slide, Picture("prettify/PrezPal_Reg.png"));
                bg.X = "0px";
                bg.Y = "0px";
                bg.Width = "13.3in";
                bg.Height = "7.5in";
                try
                    replace(slide, "Content", Picture(slideJson.Content1))
                catch
                    replace(slide, "Content", slideJson.Content1)
                end

            % Create Two Content slide if all fields are given
            else
                slide = add(ppt, "Two Content");
                bg = add(slide, Picture("prettify/PrezPal_Comparison.png"));
                bg.X = "0px";
                bg.Y = "0px";
                bg.Width = "13.3in";
                bg.Height = "7.5in";
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

            % Fill title, close slide, and present
            replace(slide, "Title", slideJson.Title)
            close(ppt);
            pptview(obj.pptxPath)
        end
    end
end