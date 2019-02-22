open OpenCvSharp.CPlusPlus
open Utils
open OpenCvSharp


let findMarker = 
    let contours = ref [||]
    let hierarchy = new Mat()
    fun img ->
        Cv2.FindContours(!> img, contours, !> hierarchy, ContourRetrieval.Tree, ContourChain.ApproxNone)
        match !contours with
        | [||] -> None
        | x when x |> Array.exists (fun x -> x.Width + x.Height > 30) -> x |> Array.maxBy (fun x -> x.Width + x.Height) |> Some
        | _ -> None

let getThreshold = 
    let hsvImg = new Mat()
    let tresholdImg = new Mat()
    fun img -> 
        Cv2.CvtColor(!> img, !> hsvImg, OpenCvSharp.ColorConversion.BgrToHsv)
        Cv2.InRange(!> hsvImg, new Scalar(100., 190., 80.), new Scalar(120., 255., 255.), !> tresholdImg)
        tresholdImg

[<EntryPoint>]
let main argv = 
    let capture = new VideoCapture(CaptureDevice.Any)
    let window = new Window("capture", WindowMode.AutoSize)
    let img = new Mat()
    let rec infLoop () = 
        capture.Read img
        img
        |> getThreshold
        |> findMarker
        |> Option.map 
            (fun x -> 
                let rect = Cv2.MinAreaRect(!> x : InputArray).BoundingRect()
                Cv2.Rectangle(img, rect, new Scalar(0., 0., 255.), 7))
        |> ignore

        window.ShowImage img
        Cv2.WaitKey 50 |> ignore
        infLoop ()
    infLoop ()
    0