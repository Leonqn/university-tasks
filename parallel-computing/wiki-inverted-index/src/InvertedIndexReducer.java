import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Cluster;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.*;

public class InvertedIndexReducer extends Reducer<Text, Text, NullWritable, Text> {

    private double totalDocuments;

    @Override
    public void setup(Context context) throws IOException, InterruptedException{
        Configuration conf = context.getConfiguration();
        Cluster cluster = new Cluster(conf);
        Job currentJob = cluster.getJob(context.getJobID());
        totalDocuments = currentJob.getCounters().findCounter(TotalCount.COUNT).getValue();
    }

    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        int docsCount = 0;
        Map<String, Double> docIdToTfMap = new HashMap<>();
        for (Text text: values) {
            String[] docIdAndTf = text.toString().split("\t");
            docIdToTfMap.put(docIdAndTf[0], Double.parseDouble(docIdAndTf[1]));
            docsCount++;
        }
        TreeMap<Double, String> TfIdfToDocIdSortedMap = new TreeMap<>();
        for (Map.Entry<String, Double> docIdAndTf : docIdToTfMap.entrySet()) {
            double tfIdf = docIdAndTf.getValue() *  Math.log(totalDocuments / docsCount);
            TfIdfToDocIdSortedMap.put(tfIdf, docIdAndTf.getKey());
            if (TfIdfToDocIdSortedMap.size() > 20)
                TfIdfToDocIdSortedMap.remove(TfIdfToDocIdSortedMap.firstKey());
        }
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(key.toString());
        for (Map.Entry<Double, String> tfIdfAndDocId : TfIdfToDocIdSortedMap.descendingMap().entrySet()) {
            stringBuilder.append("\t")
                    .append(tfIdfAndDocId.getValue())
                    .append(":")
                    .append(tfIdfAndDocId.getKey());
        }
        context.write(NullWritable.get(), new Text(stringBuilder.toString()));
    }
}
