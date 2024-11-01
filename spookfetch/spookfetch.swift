import Foundation

class SystemData {
    var uptime: String
    var kernel: String
    var architecture: String
    var hostname: String
    var user: String
    var shell: String

    init(uptime: String, kernel: String, architecture: String, hostname: String, user: String, shell: String) {
        self.uptime = uptime
        self.kernel = kernel
        self.architecture = architecture
        self.hostname = hostname
        self.user = user
        self.shell = shell
    }
}

func runShellCommand(command: String) -> String {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.arguments = ["-c", command]
    let pipe = Pipe()
    task.standardOutput = pipe
    do {
        try task.run()
    } catch {
        print("Error running shell command: \(error)")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}

func getSystemData() -> SystemData {
    let uptime = runShellCommand(command: "uptime -p")
    let kernel = runShellCommand(command: "uname -r")
    let architecture = runShellCommand(command: "uname -m")
    let hostname = runShellCommand(command: "hostname")
    let user = runShellCommand(command: "whoami")
    let shell = runShellCommand(command: "echo $SHELL")

    return SystemData(uptime: uptime, kernel: kernel, architecture: architecture, hostname: hostname, user: user, shell: shell)
}

let systemData = getSystemData()

