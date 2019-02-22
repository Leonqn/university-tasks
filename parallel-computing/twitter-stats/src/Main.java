import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import java.io.IOException;

public class Main extends Configured implements Tool{
    public static void main(String[] args) throws Exception {
        int exitCode = ToolRunner.run(new Main(), args);
        System.exit(exitCode);
    }


    public int run(String[] args) throws Exception {
        int i = runSumFollowersByUser(args[0], args[1]);
        if (i != 0)
            return i;
        i = runIntervals(args[1], args[2]);
        if (i != 0)
            return i;
        i = runAverageFollowers(args[1], args[3]);
        if (i != 0)
            return i;
        i = runTop50(args[1], args[4]);
        return i;

    }

    private int runIntervals(String inputFile, String outputFile) throws IOException, ClassNotFoundException, InterruptedException {
        Job job = Job.getInstance(super.getConf(), "intervals");
        job.setJarByClass(getClass());
        job.setMapperClass(IntervalsMapper.class);
        job.setCombinerClass(IntervalsReducer.class);
        job.setReducerClass(IntervalsReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);
        FileInputFormat.addInputPath(job, new Path(inputFile));
        FileOutputFormat.setOutputPath(job, new Path(outputFile));
        return job.waitForCompletion(true) ? 0 : 1;
    }

    private int runAverageFollowers(String inputFile, String outputFile) throws IOException, ClassNotFoundException, InterruptedException {
        Job job = Job.getInstance(super.getConf(), "averageFollowers");
        job.setJarByClass(getClass());
        job.setMapperClass(AverageFollowersMapper.class);
        job.setReducerClass(AverageFollowersReducer.class);
        job.setMapOutputValueClass(IntWritable.class);
        job.setOutputKeyClass(NullWritable.class);
        job.setOutputValueClass(DoubleWritable.class);
        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);
        FileInputFormat.addInputPath(job, new Path(inputFile));
        FileOutputFormat.setOutputPath(job, new Path(outputFile));
        return job.waitForCompletion(true) ? 0 : 1;
    }

    private int runTop50(String inputFile, String outputFile) throws IOException, ClassNotFoundException, InterruptedException {
        Job job = Job.getInstance(super.getConf(), "top50");
        job.setJarByClass(getClass());
        job.setMapperClass(Top50UsersByFollowersMapper.class);
        job.setReducerClass(Top50UsersByFollowersReducer.class);
        job.setMapOutputKeyClass(NullWritable.class);
        job.setMapOutputValueClass(Text.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);
        FileInputFormat.addInputPath(job, new Path(inputFile));
        FileOutputFormat.setOutputPath(job, new Path(outputFile));
        return job.waitForCompletion(true) ? 0 : 1;
    }

    private int runSumFollowersByUser(String inputFile, String outputFile) throws IOException, InterruptedException, ClassNotFoundException {
        Job job = Job.getInstance(super.getConf(), "sumFollowersByUser");
        job.setJarByClass(getClass());
        job.setMapperClass(SumFollowersByUserMapper.class);
        job.setCombinerClass(SumFollowersByUserReducer.class);
        job.setReducerClass(SumFollowersByUserReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);
        FileInputFormat.addInputPath(job, new Path(inputFile));
        FileOutputFormat.setOutputPath(job, new Path(outputFile));
        return job.waitForCompletion(true) ? 0 : 1;
    }
}
