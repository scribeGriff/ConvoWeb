# ConvoWeb #

## A signal processing webapp in Dart ##

Very preliminary and very much a work in progress.  In other words, we're just getting started.  

----------

## Application Description ##
The application is intended to provide a web based data analysis tool in the tradition of Octave, Scilab, etc.: 

1.  Provide a sandbox playground for performing and experimenting with a variety of signal processing functions powered by ConvoLab
2.  Full featured plotting in both 2D and 3D 
3.  Server access through websockets

More details to come.

----------  
## Example Usage: ##
Sandbox sequence might look something like:

    >> var x = [0, 1, 2, 3];
    >> var y = fft(x);
    >> p1 = plot(y.real);
    >> p1.grid();
    >> p1.xlabel('Samples (n)');
    >> p1.ylabel('data');
    >> p1.title('FFT of Samples');
    >> p1.date(true);

A simple websocket access:

    void main() {
      String host = 'local';
      int port = 8080;
      var request = 'Send data request';
      var display = query('#text');
      Future reqData = requestDataWS(host, port, request, display);
      reqData.then((data) {
        List real = data["real"];
        List imag = data["imag"];
        plot(real, 1, 2);
        plot(imag, 2, 2);
      });
    }

A sample plot:

![](http://www.scribegriff.com/dartlang/github/Convolab/ConvoWeb/ConvoWeb-Plotting.jpg)

