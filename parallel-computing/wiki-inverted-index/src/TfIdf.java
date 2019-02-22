import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

public class TfIdf {

    private static Pattern pattern = Pattern.compile("\\P{L}");

    public static Map<String, Double> getTfForEachWord(String content) {
        String[] words = pattern.split(content);
        Map<String, Integer> wordToFreqMap = new HashMap<>(words.length);
        int emptyStringsCount = 0;
        for (String word : words) {
            if (word.equals("")) {
                emptyStringsCount++;
                continue;
            }
            Integer wordFreq = wordToFreqMap.get(word);
            wordToFreqMap.put(word, wordFreq == null ? 1 : wordFreq + 1);
        }
        Map<String, Double> tfs = new HashMap<>(wordToFreqMap.size());
        for (Map.Entry<String, Integer> wordFreq : wordToFreqMap.entrySet()) {
            tfs.put(wordFreq.getKey(), (double) wordFreq.getValue() / (words.length - emptyStringsCount));
        }
        return tfs;
    }
}
