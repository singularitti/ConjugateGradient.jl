using ConjugateGradient
using Documenter

DocMeta.setdocmeta!(ConjugateGradient, :DocTestSetup, :(using ConjugateGradient); recursive=true)

makedocs(;
    modules=[ConjugateGradient],
    authors="singularitti <singularitti@outlook.com> and contributors",
    sitename="ConjugateGradient.jl",
    format=Documenter.HTML(;
        canonical="https://singularitti.github.io/ConjugateGradient.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/ConjugateGradient.jl",
    devbranch="main",
)
