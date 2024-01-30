include("src/banner.jl")
include("src/arg.jl")
include("src/func.jl")
include("src/logger.jl")

check_arguments()
const args = ARGUMENTS()

function ParseHttpResponse(url::String)
    response::String = HttpRequest(url, args["method"])

    if args["ft"] == "html"
        HtmlSource(response)
    elseif args["ft"] == "js"
        JSSource(response)
    elseif args["ft"] == "xml"
        XMLSource(response)
    elseif args["ft"] == "php"
        PHPSource(response)
    end
end

# Extract Data From HTML Source
function HtmlSource(source::String)
    args["w"] && ExtractUrls(source)
    args["a"] && ExtractATags(source)
    args["i"] && ExtractInputTags(source)
    args["s"] && ExtractScriptTags(source)
    args["f"] && ExtractFileNames(source, args["e"])
end

# Extract Data From Given JS Source
function JSSource(source::String)
    source = "<body>\n<script>\n$source\n</script>\n</body>"
    args["p"] && ExtractScriptTags(source)
    args["w"] && ExtractUrls(source)
    args["f"] && ExtractFileNames(source, args["e"])
end

# Extract Data From Given PHP Source
function PHPSource(source::String)
    args["p"] && ExtractPHPVariables(source)
    args["w"] && ExtractUrls(source)
    args["f"] && ExtractFileNames(source,  args["e"])
end

# Extract Data From Given XML Source
function XMLSource(source::String)
    args["p"] && ExtractXMLElemnts(source)
    args["w"] && ExtractUrls(source)
    args["f"] && ExtractFileNames(source, args["e"])
end

function HtmlRequestText(source::String)
    if args["p"]
        ExtractScriptTags(source)
        ExtractInputTags(source)
    end
    args["w"] && ExtractUrls(source)
    args["f"] && ExtractFileNames(source,  args["e"])
end

function HtmlResponseText(source::String)
    if args["p"]
        ExtractScriptTags(source)
        ExtractInputTags(source)
    end
    args["w"] && ExtractUrls(source)
    args["f"] && ExtractFileNames(source,  args["e"])
end


function main()

    log_message()

    # # Manage Passed Headers
    WriteFile("src/headers.txt", "w+", join(args["Header"], "\n"))

    # Call Functions
    if !isnothing(args["url"])
        ParseHttpResponse(args["url"])
    end

    if !isnothing(args["urls"])
        Threads.@threads for url in readlines(args["urls"])
            try
                ParseHttpResponse(url)
            catch e
                @error """something wrong with $(args["urls"])"""
                exit(0)
            end
        end
    end

    if !isnothing(args["source"])
        HtmlFile = ReadFile(args["source"])
        HtmlSource(HtmlFile)
    end

    if !isnothing(args["js"])
        JSFile = ReadFile(args["js"])
        JSSource(JSFile)
    end

    if !isnothing(args["php"])
        PHPFile = ReadFile(args["php"])
        PHPSource(PHPFile)
    end

    if !isnothing(args["xml"])
        XMLFile = ReadFile(args["xml"])
        XMLSource(XMLFile)
    end

    if !isnothing(args["request"])
        HtmlRequestFile = ReadFile(args["request"])
        HtmlRequestText(HtmlRequestFile)
    end

    if !isnothing(args["response"])
        HtmlResponseFile = ReadFile(args["response"])
        HtmlResponseText(HtmlResponseFile)
    end

    if args["c"]
        CountItems(false)
        exit(0)
    elseif args["cn"]
        CountItems(true)
        exit(0)
    end

    Data = union(
        Extracted_Parameters,
        Extracted_JS_Objects,
        Extracted_Variables,
        Extracted_URLS,
        Extracted_FILE_NAMES
    )

    @info "$(length(Data)) Items Found"

    if !isnothing(args["output"])
        WriteFile(args["output"], "w+", join(Data, "\n"))
        @info "data saved in file: $(args["output"])"
    else
        print(join(Data, "\n"))
    end
end

main()