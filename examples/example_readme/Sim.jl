
using Base.Threads
using WGLMakie
WGLMakie.activate!()
using JSServe
using Markdown
import JSServe.TailwindDashboard as D

# 1. LOAD LIBRARY   
using CssMakieLayout


config = Dict(
    :resolution => (1400, 700), #used for the main figures
    :colorscheme => ["rgb(242, 242, 247)", "black", "#000529", "white"]

)

landing = App() do session::Session
    CssMakieLayout.CurrentSession = session

    # Active index: 1 2 or 3
    #   1: the first a.k.a 'a' figure is active
    #   2: the second a.k.a 'b' figure is active    
    #   3: the third a.k.a 'c' figure is active
    activeidx = Observable(1)

    # Create the buttons and the mainfigures
    mainfigures = [Figure(backgroundcolor=:white,  resolution=config[:resolution]) for _ in 1:3]
    
    buttons = [button(wrap(DOM.h1("〈")); observable=activeidx, cap=3, type=:decreasecap),
               button(wrap(DOM.h1("〉")); observable=activeidx, cap=3, type=:increasecap)]
    
    axii = [Axis(mainfigures[i][1, 1]) for i in 1:3]
    # Plot each of the 3 figures using your own plots!
    scatter!(axii[1], 0:0.1:10, x -> sin(x))
    scatter!(axii[2], 0:0.1:10, x -> tan(x))
    scatter!(axii[3], 0:0.1:10, x -> log(x))

    # Obtain the reactive layout using a zstack controlled by the activeidx observable
    activefig = zstack(
                active(mainfigures[1]),
                wrap(mainfigures[2]),
                wrap(mainfigures[3]);
                observable=activeidx,
                style="width: $(config[:resolution][1])px")
    

    layout = hstack(buttons[1], activefig, buttons[2])
    
    
    return hstack(CssMakieLayout.formatstyle, layout)

end


isdefined(Main, :server) && close(server);
port = 8888
interface = "127.0.0.1"
proxy_url = ""
server = JSServe.Server(interface, port; proxy_url);
JSServe.HTTPServer.start(server)
JSServe.route!(server, "/" => landing);

wait(server)