/*
https://adventofcode.com/2024/day/5
To run it, use the command: javac Day5_1.java && java Day5_1 < input.txt
*/
import java.io.*;
import java.util.*;

public class Day5_1 {
    public static void main(String[] args) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        // Rules: a|b means a must come before b.
        // We'll store as adjacency: a -> set of b's that must come after a.
        Map<Integer, Set<Integer>> after = new HashMap<>();

        List<int[]> updates = new ArrayList<>();

        boolean readingRules = true;
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) {
                readingRules = false;
                continue;
            }

            if (readingRules) {
                String[] parts = line.split("\\|");
                int a = Integer.parseInt(parts[0]);
                int b = Integer.parseInt(parts[1]);
                after.computeIfAbsent(a, k -> new HashSet<>()).add(b);
            } else {
                String[] parts = line.split(",");
                int[] upd = new int[parts.length];
                for (int i = 0; i < parts.length; i++) upd[i] = Integer.parseInt(parts[i]);
                updates.add(upd);
            }
        }

        long sum = 0;

        for (int[] upd : updates) {
            if (isValidUpdate(upd, after)) {
                sum += upd[upd.length / 2];
            }
        }

        System.out.println(sum);
    }

    private static boolean isValidUpdate(int[] upd, Map<Integer, Set<Integer>> after) {
        // position map: page -> index in this update
        Map<Integer, Integer> pos = new HashMap<>(upd.length * 2);
        for (int i = 0; i < upd.length; i++) pos.put(upd[i], i);

        // Check every rule a -> b that is relevant (both appear in the update)
        for (Map.Entry<Integer, Set<Integer>> e : after.entrySet()) {
            int a = e.getKey();
            Integer ia = pos.get(a);
            if (ia == null) continue; // a not in this update

            for (int b : e.getValue()) {
                Integer ib = pos.get(b);
                if (ib == null) continue; // b not in this update
                if (ia > ib) return false; // violates ordering
            }
        }
        return true;
    }
}
