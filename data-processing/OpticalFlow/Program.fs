open OpenCvSharp.CPlusPlus
open OpenCvSharp
open Utils
open System
open System.Diagnostics

type Speed = Point

type Position = Point

type BallState = 
    { Color: Scalar
      Size: int
      Position: Position
      Speed: Speed }

let toGray = 
    let grayImg = new Mat()
    let prevGrayImg = new Mat()
    fun (img: Mat, prevImg: Mat) ->
        Cv2.CvtColor(!> img, !> grayImg, ColorConversion.BgrToGray)
        Cv2.CvtColor(!> prevImg, !> prevGrayImg, ColorConversion.BgrToGray)
        (grayImg, prevGrayImg)

let createBalls count windowWidth windowHeight = 
    let rng = Random()
    let next min max= rng.Next(min, max) |> float
    List.init count (fun _ -> 
          let size = next 20 40 |> int
          { Color = Scalar(next 0 255, next 0 255, next 0 255)
            Size = size
            Position = Position(next size windowWidth, next size windowHeight)
            Speed = Speed() })
        
let getSummaryVector (flow: Mat) w h  ball = 
    let iterList = [-ball.Size .. ball.Size - 1]
    let points: Point[] = 
        [| for y1 in iterList do
             for x1 in iterList do
                 if x1*x1 + y1*y1 <= ball.Size * ball.Size then
                     let x2 = ball.Position.X + x1
                     let y2 = ball.Position.Y + y1
                     if x2 >= 0 && x2 < w && y2 >= 0 && y2 < h then
                         let point = flow.At<Point2d>(y2, x2)
                         if point.X*point.X + point.Y*point.Y <= float (w / 10 * w / 10) then
                             yield !> point |]
    match points with
    | [||] -> Point()
    | _ ->
        points
        |> Array.reduce (+)
        |> fun x -> x * (1.0 / float points.Length)

let makeSomePhysics flow w h (dt: float) ball =
    let force = getSummaryVector flow w h ball
    let speed = (ball.Speed + force * 200. * dt) * 0.75
    let position = ball.Position + speed * dt
    { ball with Position = position; Speed = speed }


let checkBorders w h ball =
    let mutable p, s = ball.Position, ball.Speed
    if p.X < 0 then
        p.X <- p.X * -1; 
        if s.X < 0 then s.X <- s.X * -1
    if p.X >= w then
        p.X <- 2 * (w - 1) - p.X
        if s.X > 0 then s.X <- s.X * -1
    
    if p.Y < 0 then
        p.Y <- p.Y * -1; 
        if s.Y < 0 then s.Y <- s.Y * -1
    if p.Y >= h then
        p.Y <- 2 * (h - 1) - p.Y
        if s.Y > 0 then s.Y <- s.Y * -1;        
    {ball with Position = p; Speed = s}

let getNewBalls flow w h balls dt =
    balls |> List.map (makeSomePhysics flow w h dt >> checkBorders w h)

[<EntryPoint>]
let main argv = 
    let capture = new VideoCapture(CaptureDevice.Any)
    let window = new Window("capture", WindowMode.AutoSize)
    let width = capture.FrameWidth
    let height = capture.FrameHeight
    let img, prevImg, flow = new Mat(), new Mat(), new Mat()
    let sw = Stopwatch.StartNew()
    let balls = createBalls 25 width height
    let getSeconds () = (float sw.ElapsedMilliseconds / 1000.)
    
    let rec show balls prevTIme =
        capture.Read img
        let nowTime = getSeconds()
        if prevImg.Empty() then
            img.CopyTo prevImg
            show balls nowTime
        let dt = nowTime - prevTIme
        let gray, prevGray = toGray (img, prevImg)
        Cv2.CalcOpticalFlowFarneback(!> prevGray, !> gray, !> flow, 0.5, 3, 15, 3, 5, 1.2, OpticalFlowFlags.None)
        let newBalls = getNewBalls flow width height balls dt
        balls |> List.iter (fun x -> Cv2.Circle(prevImg, x.Position, x.Size, x.Color, -1))
        window.ShowImage prevImg
        Cv2.WaitKey 20 |> ignore
        img.CopyTo prevImg
        show newBalls nowTime

    show balls (getSeconds())
    0
