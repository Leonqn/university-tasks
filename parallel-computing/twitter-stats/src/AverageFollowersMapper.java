import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

public class AverageFollowersMapper extends Mapper<LongWritable, Text, NullWritable, IntWritable> {
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        IntWritable followersCount = new IntWritable(Integer.parseInt(value.toString().split("\t")[1]));
        context.write(NullWritable.get(), followersCount);
    }
}
