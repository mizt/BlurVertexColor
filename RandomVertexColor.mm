#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import <vector>

inline float frand() { return (random()%256)/255.0; }

int main(int argc, char *argv[]) {
	@autoreleasepool {

		srandom(20230904);
	
		NSMutableString *obj = [NSMutableString stringWithString:@""];
		
		for(int i=0; i<5; i++) {
			
			float y1 = (i/5.0)*2.0-1.0;
			float y2 = ((i+1.0)/5.0)*2.0-1.0;
			
			for(int j=0; j<5; j++) {
				
				float x1 = (j/5.0)*2.0-1.0;
				float x2 = ((j+1)/5.0)*2.0-1.0;
				
				[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f 0.0 %0.4f %0.4f %0.4f\n",x1,y1,frand(),frand(),frand()]];
				[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f 0.0 %0.4f %0.4f %0.4f\n",x2,y2,frand(),frand(),frand()]];
				[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f 0.0 %0.4f %0.4f %0.4f\n",x1,y2,frand(),frand(),frand()]];
			
				[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f 0.0 %0.4f %0.4f %0.4f \n",x1,y1,frand(),frand(),frand()]];
				[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f 0.0 %0.4f %0.4f %0.4f \n",x2,y1,frand(),frand(),frand()]];
				[obj appendString:[NSString stringWithFormat:@"v %0.4f %0.4f 0.0 %0.4f %0.4f %0.4f \n",x2,y2,frand(),frand(),frand()]];
			}
		}

		for(int i=0; i<5; i++) {
			for(int j=0; j<5; j++) {
			
				unsigned int f = 1+(i*5+j)*6;
				
				[obj appendString:[NSString stringWithFormat:@"f %d %d %d\n",f+0,f+1,f+2]];
				[obj appendString:[NSString stringWithFormat:@"f %d %d %d\n",f+3,f+4,f+5]];
			}
		}

		[obj writeToFile:@"plane.obj" atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}