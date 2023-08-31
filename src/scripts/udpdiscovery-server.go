package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"os/exec"
	// "strconv"
	"time"
)

const (
	PORT     = 4920
	BUFFSIZE = 1024
)

func response(request string, udpServer net.PacketConn, addr net.Addr, buf []byte) {
	if request == "*" {
		adapterType := "adapter type" + "=" + "sl-raspi"
		adapterNick, _ := os.Hostname()
		adapterNick = "adapter nick" + "=" + adapterNick
		adapterNetIf, _ := getLocalIP()
		adapterNetIf = "adapter netif" + "=" + adapterNetIf
		firmwareType_Out, _ := exec.Command("service", "--status-all").Output()
		firmwareType := string(firmwareType_Out[:])
		firmwareVersion_Out, _ := exec.Command("sudo", "rpi-eeprom-update").Output()
		firmwareVersion := string(firmwareVersion_Out[:])
		time := time.Now().Format(time.ANSIC)
		responseStr := fmt.Sprintf("%v\n%v\n%v\n%v\n%v\n%v", time, adapterType, adapterNick, adapterNetIf, firmwareType, firmwareVersion)
		
		udpServer.WriteTo([]byte(responseStr), addr)
	} else {
		fmt.Println("Invalid request.")
	}
}

func getLocalIP() (string, error) {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return "", err
	}

	for _, addr := range addrs {
		if ipNet, ok := addr.(*net.IPNet); ok && !ipNet.IP.IsLoopback() && ipNet.IP.To4() != nil {
			return ipNet.IP.String(), nil
		}
	}

	return "", fmt.Errorf("failed to determine local IP address")
}

func main() {
        addr, err := net.ResolveUDPAddr("udp", fmt.Sprintf(":%d", PORT))
        if err != nil {
           	fmt.Println("Failed to resolve UDP address:", err)
           	return
        }
	// listen to incoming udp packets on port 4920
	//udpServer, err := net.ListenPacket("udp", strconv.Itoa(PORT))
	udpServer, err := net.ListenUDP("udp", addr)
	if err != nil {		
		fmt.Println("Failed to listen udp package:", err)
		log.Fatal(err)
	}
	defer udpServer.Close()

	fmt.Printf("Listening on UDP port %d...\n", PORT)

	// Loop to read udp packet from the listening port 4920
	for {
		buf := make([]byte, BUFFSIZE)
		n, addr, err := udpServer.ReadFrom(buf)
		if err != nil {
			fmt.Println("Error reading UDP request:", err)
			continue
		}
		request := string(buf[:n])
		go response(request, udpServer, addr, buf)
	}

}
