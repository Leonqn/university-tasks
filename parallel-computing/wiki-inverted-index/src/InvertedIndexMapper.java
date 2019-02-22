import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;
import java.util.Map;

public class InvertedIndexMapper extends Mapper<LongWritable, Text, Text, Text> {

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        String[] docIdAndContent = value.toString().split("\t");
        String docId = docIdAndContent[0];
        String content = docIdAndContent[1];
        Map<String, Double> tfForEachWord = TfIdf.getTfForEachWord(content.toLowerCase());
        context.getCounter(TotalCount.COUNT).increment(1);
        for (Map.Entry<String, Double> tf : tfForEachWord.entrySet()) {
            context.write(new Text(tf.getKey()), new Text(docId + "\t" + tf.getValue()));
        }
    }
}
