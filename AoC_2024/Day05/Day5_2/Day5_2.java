/*
https://adventofcode.com/2024/day/5
To run it, use the command: javac Day5_2.java && java Day5_2 < input.txt
*/
import java.io.*;
import java.util.*;

public class Day5_2 {
    public static void main(String[] args) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

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
            if (!isValidUpdate(upd, after)) {
                int[] fixed = topoFix(upd, after);
                sum += fixed[fixed.length / 2];
            }
        }

        System.out.println(sum);
    }

    private static boolean isValidUpdate(int[] upd, Map<Integer, Set<Integer>> after) {
        Map<Integer, Integer> pos = new HashMap<>(upd.length * 2);
        for (int i = 0; i < upd.length; i++) pos.put(upd[i], i);

        for (Map.Entry<Integer, Set<Integer>> e : after.entrySet()) {
            int a = e.getKey();
            Integer ia = pos.get(a);
            if (ia == null) continue;
            for (int b : e.getValue()) {
                Integer ib = pos.get(b);
                if (ib == null) continue;
                if (ia > ib) return false;
            }
        }
        return true;
    }

    private static int[] topoFix(int[] upd, Map<Integer, Set<Integer>> after) {
        // Nodes in this update
        Set<Integer> nodes = new HashSet<>();
        for (int x : upd) nodes.add(x);

        // Build induced graph + indegree
        Map<Integer, List<Integer>> g = new HashMap<>();
        Map<Integer, Integer> indeg = new HashMap<>();
        for (int x : upd) {
            g.put(x, new ArrayList<>());
            indeg.put(x, 0);
        }

        for (Map.Entry<Integer, Set<Integer>> e : after.entrySet()) {
            int a = e.getKey();
            if (!nodes.contains(a)) continue;
            for (int b : e.getValue()) {
                if (!nodes.contains(b)) continue;
                g.get(a).add(b);
                indeg.put(b, indeg.get(b) + 1);
            }
        }

        // Deterministic topo order: smallest available first
        PriorityQueue<Integer> pq = new PriorityQueue<>();
        for (int x : upd) {
            if (indeg.get(x) == 0) pq.add(x);
        }

        int[] out = new int[upd.length];
        int idx = 0;

        while (!pq.isEmpty()) {
            int u = pq.poll();
            out[idx++] = u;
            for (int v : g.get(u)) {
                int d = indeg.get(v) - 1;
                indeg.put(v, d);
                if (d == 0) pq.add(v);
            }
        }

        // If idx != upd.length, there was a cycle in the induced constraints.
        // AoC input should avoid this. If it happens, fail loudly.
        if (idx != upd.length) {
            throw new IllegalStateException("Cycle detected while sorting an update.");
        }

        return out;
    }
}
