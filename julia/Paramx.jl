include("./src/banner.jl")
include("./src/arg.jl")
include("./src/func.jl")
using HTTP
using Gumbo

function URL(url::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    req::HTTP.Messages.Response = HTTP.get(url)
    source::String = req.body |> String
    html::HTMLDocument = parsehtml(String(req.body))
    CALL(source, html, a=a, i=i, s=s, w=w, f=f, e=e)
    OUT(o)
end

function URLS(file::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    Threads.@threads for url in readlines(file)
        URL(url, a, i, s, w, f, e, o)
    end
end

function SOURCE(file::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    html::HTMLDocument = parsehtml(source)
    CALL(source, html, a=a, i=i, s=s, w=w, f=f, e=e)
    OUT(o)
end

function REQUEST(file::String, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    CALL2(source, m=p, w=w, f=f, e=e)
    OUT(o)
end

function RESPONSE(file::String, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    CALL2(source, m=p, w=w, f=f, e=e)
    OUT(o)
end

function JS(file::String, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    html::HTMLDocument = parsehtml("<body><script>$source</script></body>")
    CALL(source, html, s=p, w=w, f=f, e=e)
    OUT(o)
end

function PHP(file::String, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    CALL2(source, p=p, w=w ,f=f, e=e)
    OUT(o)
end

function XML(file::String, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    CALL2(source, x=p, w=w, f=f, e=e)
    OUT(o)
end

function main()
    check_arguments()
    arguments = ARGUMENTS()

    a = arguments["a"]
    i = arguments["i"]
    s = arguments["script"]
    w = arguments["w"]
    p = arguments["p"]
    f = arguments["file-names"]
    e = arguments["extension"]
    o = arguments["output"]

    !isnothing(arguments["url"]) && URL(arguments["url"], a, i, s, w, f, e, o)
    !isnothing(arguments["urls"]) && URLS(arguments["urls"], a, i, s, w, f, e, o)
    !isnothing(arguments["source"]) && SOURCE(arguments["source"], a, i, s, w, f, e, o)
    !isnothing(arguments["request"]) && REQUEST(arguments["request"], p, w, f, e, o)
    !isnothing(arguments["response"]) && RESPONSE(arguments["response"], p, w, f, e, o)
    !isnothing(arguments["js"]) && JS(arguments["js"], p, w, f, e, o)
    !isnothing(arguments["php"]) && PHP(arguments["php"], p, w, f, e, o)
    !isnothing(arguments["xml"]) && XML(arguments["xml"], p, w, f, e, o)
end

main()