import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class IntervalsReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
        int sumUsers = 0;
        for (IntWritable val: values) {
            sumUsers += val.get();
        }
        context.write(key, new IntWritable(sumUsers));
    }
}
