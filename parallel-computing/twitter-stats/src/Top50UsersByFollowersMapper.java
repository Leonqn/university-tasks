import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

public class Top50UsersByFollowersMapper extends Mapper<LongWritable, Text, NullWritable, Text> {
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        String[] userIdAndFollowersCount = value.toString().split("\t");
        String userId = userIdAndFollowersCount[0];
        Integer followersCount = Integer.parseInt(userIdAndFollowersCount[1]);
        context.write(NullWritable.get(), new Text(userId + "\t" + followersCount));
    }
}
