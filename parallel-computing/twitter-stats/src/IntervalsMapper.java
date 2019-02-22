import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

public class IntervalsMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        Integer followersCount = Integer.parseInt(value.toString().split("\t")[1]);
        Integer openInterval = (int) Math.pow(10, followersCount.toString().length() - 1);
        Integer endInterval = (int) Math.pow(10, openInterval.toString().length());
        String interval = "[" + openInterval + ", " + endInterval + "]";
        context.write(new Text(interval), new IntWritable(1));
    }
}
