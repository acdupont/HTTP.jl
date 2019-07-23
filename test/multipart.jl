@testset "HTTP.Form for multipart/form-data" begin
    headers = Dict("User-Agent" => "HTTP.jl")
    body = HTTP.Form(Dict())
    uri = "https://httpbin.org/post"
    @testset "Setting of Content-Type" begin
        for r in (HTTP.request("POST", uri, headers, body), HTTP.post(uri, headers, body))
            @test r.status == 200
            json = JSON.parse(IOBuffer(HTTP.payload(r)))
            @test startswith(json["headers"]["Content-Type"], "multipart/form-data; boundary=")
        end
    end
    @testset "Deprecation of HTTP.post without header for body::Form" begin
        proj = normpath(joinpath(pathof(HTTP), "..", "..", "Project.toml"))
        # Extract version = "(...)" from Project.toml
        vers = VersionNumber(match(r"^version\s*=\s*\"(.*?)\"$"m, read(proj, String)).captures[1])
        if vers.minor == 8 # this version
            HTTP.post(uri, body).status == 200
        elseif vers.minor == 9 || vers.major == 1 # Next breaking release
            @test_logs (:warn, r"deprecated") HTTP.post(uri, body).status == 200
        else # two breaking versions from now
            @test_throws MethodError HTTP.post(uri, body)
        end
    end

@testset "Multipart" begin
    @testset "show" begin
        # testing that there is no error in printing when nothing is set for filename
        try
            show(HTTP.Multipart(nothing, IOBuffer("some data"), "plain/text", "", "testname"))
            println("")
            @test true
        catch exception
            @error "" typeof(exception) exception
            @test false
        end
    end
    
    
    @testset "constructor" begin
        @testset "don't allow String for data" begin
            @test_throws MethodError HTTP.Multipart(nothing, "some data", "plain/text", "", "testname")
        end
    end
end
