# ARHoleInTheGround
A prototype AR hole, the hole contains a live stream of another phone that is broadcasting a live twitch stream. The broadcasting phone can be either android or ios device. The device recieving the stream and rendering an AR hole has to be a IOS device that can run ARKit.

The MP4 file is a demo file.

The slipperystonework texture is from freepbr.com

The environment.jpg/environment_blur.exr is from Apple demo

In order to have the right HLS url to tune into, use Streamlink in python2 or 3 to get the realtime url.
Important to note that it will change with every rebroadcast of the stream.

## Author
Eric Chan / [@erirrows](https://twitter.com/erirrows)

## For the masking technique and base framework
Bjarne Lundgren / bjarne@sent.com / [@bjarnel](https://twitter.com/bjarnel)
