# ConvoWeb #

## A signal processing webapp in Dart ##

A client side data visualization application for use with the signal processing algorithms in ConvoLab.  

----------

## Application Description ##
The application is intended to provide a web based data analysis tool in the tradition of Octave, Scilab, etc.: 

1.  Provide a sandbox playground for performing and experimenting with a variety of signal processing functions powered by ConvoLab
2.  Full featured plotting in both 2D and 3D 
3.  Server access through websockets

Can import the ConvoLab algorithm library directly or communicate with the server side application ConvoHio using websockets.

----------  
## Example Usage: ##
Sandbox sequence might look something like:

    >> var x = [0, 1, 2, 3];
    >> var y = fft(x);
    >> p1 = plot(y.real);
    >> p1.grid();
    >> p1.xlabel('time (samples)');
    >> p1.ylabel('amplitude');
    >> p1.title('Waveform');
    >> p1.date(true);

Simple websocket access:

    import 'package:convolab/convolab.dart';
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

A sample plot from the plotting tool:

![](http://www.scribegriff.com/dartlang/github/Convolab/ConvoWeb/ConvoWeb-Plotting-Sound.png)

