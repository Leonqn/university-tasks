import org.apache.spark.SparkContext
import org.apache.spark.rdd.RDD


object App {
  def loadFilesAndGetScores(sc: SparkContext, pathToFiles: String) = {
    val texts = sc.wholeTextFiles(pathToFiles)
    val docs = tokenize(texts).cache()
    val idfs = getIdfs(docs.count(), docs).collectAsMap()
    val avgdl = calcAvgdl(docs)
    getScores(docs, idfs, avgdl).cache()
  }

  def calcAvgdl(docs: RDD[(String, Array[String])]) =
    docs.map(_._2.length).reduce(_ + _)

  def tokenize(docs: RDD[(String, String)]) =
    docs.mapValues(_.split("\\P{L}").filterNot(_.isEmpty()))

  def getIdfs(docsCount: Long, docs: RDD[(String, Array[String])]) =
    docs
      .flatMap({ case (docId, words) => words.map((_, docId)) })
      .groupByKey()
      .mapValues({ docIds =>
        val size = docIds.size
        (docsCount - size + 0.5) / (size + 0.5)
      })

  def getScores(docs: RDD[(String, Array[String])], idfs: scala.collection.Map[String, Double], avgdl: Double) =
    docs.flatMap({ case (docId, words) =>
      val wordsCount = words.groupBy(s => s).mapValues(_.length)
      words
        .distinct
        .map(word => (word, (docId, (idfs(word) * wordsCount(word) * 2.2) / (wordsCount(word) + 1.2 * (0.5 + 0.5*words.length/avgdl)))))
    })
      .groupByKey()
      .mapValues(_.toArray.sortBy(_._2).reverse)

  def findTop(query: String, take: Int, scores: RDD[(String, Array[(String, Double)])]) =
    query
    .split("\\P{L}")
    .filterNot(_.isEmpty())
    .flatMap(scores.lookup(_).head.take(take))
    .groupBy(_._1)
    .mapValues(_.map(_._2).sum)
    .toArray
    .sortBy(_._2)
    .reverse
    .map(_._1)
    .take(take)
}
