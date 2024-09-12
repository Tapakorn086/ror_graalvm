import java.io.BufferedReader;
import java.io.InputStreamReader;

public class RunRails {
    public static void main(String[] args) {
        try {
            // สั่งให้ Rails server ทำงาน
            System.out.println("START RAILS SERVER");
            ProcessBuilder builder = new ProcessBuilder("rails", "server", "-b", "0.0.0.0");
            builder.redirectErrorStream(true);
            Process process = builder.start();
            System.out.println("START RAILS SERVER");


            // อ่านและแสดงผลลัพธ์จากคำสั่ง Rails
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            System.out.println("START LOOP");
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
            System.out.println("END LOOP");


            // รอให้ process เสร็จสิ้น
            process.waitFor();
        } catch (Exception e) {
            System.out.println("BAD RAILS SERVER");
            e.printStackTrace();
        }
    }
}
