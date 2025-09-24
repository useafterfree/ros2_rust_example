// ROS2 subscriber

use rclrs::*;

fn callback(msg: std_msgs::msg::String) {
  println!("Received: '{}'", msg.data);
}

fn main() -> Result<(), anyhow::Error> {
    let context = Context::default_from_env()?;
    let mut executor = context.create_basic_executor();
    let node = executor.create_node("rust_subscriber")?;

    println!("Waiting for messages...");

    let _subscription = node.create_subscription::<std_msgs::msg::String, _>(
        "rusttopic",
        callback
    )?;

    executor.spin(SpinOptions::default());
    Ok(())
  }