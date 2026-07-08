import edu.mit.csail.sdg.alloy4viz.VizGUI;

public class AlloyViz {
    public static void main(String[] args) {
        String path = args.length > 0 ? args[0] : null;
        new VizGUI(true, path, null);
    }
}
