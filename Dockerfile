FROM julia:1.9.3
RUN julia -e 'using Pkg; Pkg.add("HTTP"); Pkg.add("Gumbo"); Pkg.add("Cascadia"); Pkg.add("ArgParse"); Pkg.add("JSON")'
RUN mkdir /Paramx
WORKDIR /Paramx/
COPY . /Paramx/
ENTRYPOINT [ "julia", "/Paramx/Paramx.jl" ]
CMD [ "-h" ]