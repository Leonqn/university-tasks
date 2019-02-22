open OpenCvSharp.CPlusPlus
open OpenCvSharp
open Utils

let toGray = 
    let grayImg = new Mat()
    fun img ->
        Cv2.CvtColor(!> img, !> grayImg, ColorConversion.BgrToGray)
        grayImg

[<EntryPoint>]
let main argv = 
//  video sample http://sc.titkov.me/v.mp4
    let capture = new VideoCapture(argv.[0])
    let window = new Window("capture", WindowMode.AutoSize)
    let classifier = new CascadeClassifier("cascade.xml")
    let img = new Mat()
    let rec infLoop () = 
        capture.Read img
        img
        |> toGray
        |> classifier.DetectMultiScale
        |> Seq.iter (fun x -> Cv2.Rectangle(img, x, new Scalar(0., 0., 255.), 7))
        window.ShowImage img
        Cv2.WaitKey 50 |> ignore
        infLoop ()
    infLoop ()
    0
