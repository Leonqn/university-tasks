import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class AverageFollowersReducer extends Reducer<NullWritable, IntWritable, NullWritable, DoubleWritable> {
    @Override
    protected void reduce(NullWritable key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
        int sumFollowers = 0;
        int usersCount = 0;
        for (IntWritable val: values) {
            usersCount++;
            sumFollowers += val.get();
        }
        context.write(key, new DoubleWritable((double) sumFollowers / usersCount));
    }
}
