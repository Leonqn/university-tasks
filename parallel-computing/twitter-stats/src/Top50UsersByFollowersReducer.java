import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.Map;
import java.util.TreeMap;

public class Top50UsersByFollowersReducer extends Reducer<NullWritable, Text, Text, IntWritable> {
    @Override
    protected void reduce(NullWritable key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        TreeMap<Integer, String> sortedMap = new TreeMap<Integer, String>();
        for (Text val: values) {
            String[] userIdAndFollowersCount = val.toString().split("\t");
            String userId = userIdAndFollowersCount[0];
            Integer followersCount = Integer.parseInt(userIdAndFollowersCount[1]);
            sortedMap.put(followersCount, userId);
            if (sortedMap.size() > 50) {
                sortedMap.remove(sortedMap.firstKey());
            }
        }

        for (Map.Entry<Integer, String> val : sortedMap.entrySet()) {
            context.write(new Text(val.getValue()), new IntWritable(val.getKey()));
        }
    }
}
