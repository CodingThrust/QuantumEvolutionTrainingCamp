using RydbergToolkit
using Literate, Pkg
using Documenter

# # Literate
# using Pkg; Pkg.activate(pkgdir(RydbergToolkit, "examples")); Pkg.instantiate()
# for each in readdir(pkgdir(RydbergToolkit, "examples"))
#     input_file = pkgdir(RydbergToolkit, "examples", each)
#     endswith(input_file, ".jl") || continue
#     @info "building" input_file
#     output_dir = pkgdir(RydbergToolkit, "docs", "src", "generated")
#     Literate.markdown(input_file, output_dir; name=each[1:end-3], execute=false)
# end
# Pkg.activate(pkgdir(RydbergToolkit, "docs"))

makedocs(;
    modules=[RydbergToolkit],
    authors="GiggleLiu <cacate0129@gmail.com> and contributors",
    sitename="RydbergToolkit.jl",
    format=Documenter.HTML(;
        canonical="https://CodingThrust.github.io/RydbergToolkit.jl",
        edit_link="main",
    ),
    doctest = false,
    pages=[
        "Home" => "index.md",
        "Reference" => "ref.md",
        # "Examples" => ["generated/scar.md", "generated/wmis.md"],
    ],
    warnonly=[:missing_docs]
)

deploydocs(;
    repo="github.com/CodingThrust/RydbergToolkit.jl",
    devbranch="main",
)
