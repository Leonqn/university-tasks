name := "server"

mainClass in Compile := Some("magicalapps.server.app.Application")

scalaVersion := "2.10.3"

scalacOptions ++= Seq("-deprecation")

libraryDependencies += "io.spray" %% "spray-json" % "1.2.5"

libraryDependencies += "io.spray" % "spray-can" % "1.3.1"

libraryDependencies += "io.spray" % "spray-routing" % "1.3.1"

libraryDependencies += "io.spray" % "spray-client" % "1.3.1"

libraryDependencies += "com.typesafe.akka" % "akka-actor_2.10" % "2.3.1"

libraryDependencies  ++=  Seq(
    "org.squeryl" %% "squeryl" % "0.9.5-6",
    "postgresql" % "postgresql" % "8.4-701.jdbc4"
)

libraryDependencies += "com.github.nscala-time" %% "nscala-time" % "0.8.0"